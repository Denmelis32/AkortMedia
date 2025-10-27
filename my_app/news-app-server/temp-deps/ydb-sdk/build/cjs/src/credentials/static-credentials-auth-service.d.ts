import { ISslCredentials } from "../utils/ssl-credentials";
import * as grpc from "@grpc/grpc-js";
import { IAuthService } from "./i-auth-service";
import { Logger } from "../logger/simple-logger";
/**
 * Static credentials token.
 */
export type StaticCredentialsToken = {
    value: string;
    aud: string[];
    exp: number;
    iat: number;
    sub: string;
};
/**
 * Interface for options used in static credentials authentication.
 */
interface StaticCredentialsAuthOptions {
    /** Custom SSL certificates. If you use it in driver, you must use it here too */
    sslCredentials?: ISslCredentials;
    /**
     * Timeout for token request in milliseconds
     * @default 10 * 1000
     */
    tokenRequestTimeout?: number;
    /**
     * Expiration time for token in milliseconds
     * @deprecated Use tokenRefreshInterval instead
     * @default 6 * 60 * 60 * 1000
     */
    tokenExpirationTimeout?: number;
    /**
     * Time interval in milliseconds after which the token will be refreshed.
     * When specified, token refresh is based on this timer rather than the token's exp field.
     */
    tokenRefreshInterval?: number;
}
export declare class StaticCredentialsAuthService implements IAuthService {
    private readonly tokenRequestTimeout;
    private readonly tokenRefreshInterval;
    private readonly user;
    private readonly password;
    private readonly endpoint;
    private readonly sslCredentials;
    readonly logger: Logger;
    private token;
    private promise;
    constructor(user: string, password: string, endpoint: string, options?: StaticCredentialsAuthOptions);
    constructor(user: string, password: string, endpoint: string, loggerOrOptions: Logger | StaticCredentialsAuthOptions, options?: StaticCredentialsAuthOptions);
    private sendTokenRequest;
    private updateToken;
    getAuthMetadata(): Promise<grpc.Metadata>;
}
export {};
//# sourceMappingURL=static-credentials-auth-service.d.ts.map