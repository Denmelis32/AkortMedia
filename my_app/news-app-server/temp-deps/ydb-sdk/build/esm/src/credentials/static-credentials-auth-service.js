"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.StaticCredentialsAuthService = void 0;
const ydb_sdk_proto_1 = require("ydb-sdk-proto");
var AuthServiceResult = ydb_sdk_proto_1.Ydb.Auth.LoginResult;
const utils_1 = require("../utils");
const retries_obsoleted_1 = require("../retries_obsoleted");
const process_ydb_operation_result_1 = require("../utils/process-ydb-operation-result");
const add_credentials_to_metadata_1 = require("./add-credentials-to-metadata");
const get_default_logger_1 = require("../logger/get-default-logger");
const TOKEN_EXPIRY_MARGIN = 60; // seconds
class StaticCredentialsGrpcService extends utils_1.GrpcService {
    logger;
    constructor(endpoint, sslCredentials, logger = (0, get_default_logger_1.getDefaultLogger)()) {
        super(endpoint, 'Ydb.Auth.V1.AuthService', ydb_sdk_proto_1.Ydb.Auth.V1.AuthService, sslCredentials);
        this.logger = logger;
    }
    login(request) {
        return this.api.login(request);
    }
    destroy() {
        this.api.end();
    }
}
__decorate([
    (0, retries_obsoleted_1.retryable)()
], StaticCredentialsGrpcService.prototype, "login", null);
class StaticCredentialsAuthService {
    tokenRequestTimeout = 10 * 1000;
    tokenRefreshInterval = null;
    user;
    password;
    endpoint;
    sslCredentials;
    logger;
    token = null;
    // Mutex
    promise = null;
    constructor(user, password, endpoint, loggerOrOptions, options) {
        this.user = user;
        this.password = password;
        this.endpoint = endpoint;
        this.sslCredentials = options?.sslCredentials;
        if (typeof loggerOrOptions === 'object' && loggerOrOptions !== null && 'error' in loggerOrOptions) {
            this.logger = loggerOrOptions;
        }
        else {
            options = loggerOrOptions;
            this.logger = (0, get_default_logger_1.getDefaultLogger)();
        }
        this.logger.info(`[StaticCredentialsAuthService] Initialized for endpoint: ${this.endpoint}`);
        if (options?.tokenRequestTimeout)
            this.tokenRequestTimeout = options.tokenRequestTimeout;
        if (options?.tokenExpirationTimeout)
            this.tokenRefreshInterval = options.tokenExpirationTimeout;
        if (options?.tokenRefreshInterval)
            this.tokenRefreshInterval = options.tokenRefreshInterval;
        if (this.tokenRefreshInterval) {
            let timer = setInterval(() => {
                if (this.promise) {
                    this.logger.debug('[StaticCredentialsAuthService] Token refresh already in progress, skipping interval refresh.');
                    return;
                }
                this.logger.info('[StaticCredentialsAuthService] Periodic token refresh triggered.');
                this.promise = this.updateToken()
                    .then(token => (0, add_credentials_to_metadata_1.addCredentialsToMetadata)(token.value))
                    .finally(() => {
                    this.promise = null;
                });
            }, this.tokenRefreshInterval);
            timer.unref();
        }
    }
    async sendTokenRequest() {
        this.logger.debug('[StaticCredentialsAuthService] Sending token request...');
        let runtimeAuthService = new StaticCredentialsGrpcService(this.endpoint, this.sslCredentials, this.logger);
        const tokenPromise = runtimeAuthService.login({
            user: this.user,
            password: this.password,
        });
        const response = await (0, utils_1.withTimeout)(tokenPromise, this.tokenRequestTimeout);
        const result = AuthServiceResult.decode((0, process_ydb_operation_result_1.getOperationPayload)(response));
        runtimeAuthService.destroy();
        this.logger.debug('[StaticCredentialsAuthService] Token request completed.');
        return result;
    }
    async updateToken() {
        this.logger.info('[StaticCredentialsAuthService] Updating token...');
        const { token } = await this.sendTokenRequest();
        if (!token) {
            this.logger.error('[StaticCredentialsAuthService] Received empty token from static credentials!');
            throw new Error('Received empty token from static credentials!');
        }
        // Parse the JWT token to extract expiration time
        const [, payload] = token.split('.');
        const decodedPayload = JSON.parse(Buffer.from(payload, 'base64').toString());
        this.token = {
            value: token,
            ...decodedPayload
        };
        this.logger.info(`[StaticCredentialsAuthService] Token updated. Expires at: ${new Date(this.token.exp * 1000).toISOString()}`);
        return this.token;
    }
    async getAuthMetadata() {
        if (this.token && (this.token.exp - TOKEN_EXPIRY_MARGIN) > Date.now() / 1000) {
            return (0, add_credentials_to_metadata_1.addCredentialsToMetadata)(this.token.value);
        }
        if (this.promise) {
            return this.promise;
        }
        this.logger.info('[StaticCredentialsAuthService] Token expired or missing, refreshing...');
        this.promise = this.updateToken()
            .then(token => (0, add_credentials_to_metadata_1.addCredentialsToMetadata)(token.value))
            .finally(() => {
            this.promise = null;
        });
        return this.promise;
    }
}
exports.StaticCredentialsAuthService = StaticCredentialsAuthService;
