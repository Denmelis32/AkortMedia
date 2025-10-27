import EventEmitter from "events";
import { Metadata } from "@grpc/grpc-js";
import { Ydb } from "ydb-sdk-proto";
import { SessionCallback } from "./query-session-pool";
import { Context } from "../context";
import { IClientSettings } from "../client/settings";
interface IDoOpts<T> {
    ctx?: Context;
    txSettings?: Ydb.Query.ITransactionSettings;
    fn: SessionCallback<T>;
    timeout?: number;
    idempotent?: boolean;
    onTrailer?: (metadata: Metadata) => void;
}
/**
 * YDB Query Service client.
 *
 * # Experimental
 *
 * Notice: This API is EXPERIMENTAL and may be changed or removed in a later release.
 */
export declare class QueryClient extends EventEmitter {
    private pool;
    private logger;
    private retrier;
    constructor(settings: IClientSettings);
    destroy(): Promise<void>;
    do<T>(opts: IDoOpts<T>): Promise<T>;
    doTx<T>(opts: IDoOpts<T>): Promise<T>;
}
export {};
//# sourceMappingURL=query-client.d.ts.map