//
// Event Manager
//

class EventManager {
    eventHandlers = {};

    constructor() {
        this.eventHandlers = {};
    }

    NewEvent(e) {
        this.eventHandlers[e] = 0;
        console.log(`EventManager: New event added: ${e}`);
    }

    Subscribe(e, cb) {
        if (this.eventHandlers[e] == undefined) {
            console.error(`EventManager: Subscring undefined event: ${e}`);
        } else {
            if (this.eventHandlers[e] != 0) {
                console.warn(`EventManager: Subscribing override: ${e}`);
            }
            this.eventHandlers[e] = cb;
        }
    }

    TriggerEvent(e, param) {
        var cb = this.eventHandlers[e]
        if (cb == undefined) {
            console.warn(`EventManager: Event triggered but not listened: ${e}`);
        } else {
            console.log(`EventManager: Triggering callback: ${e}`);
            cb(param);
        }
    }
}

const eventManager = new EventManager();