"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.isRecordDeleted = isRecordDeleted;
exports.validateRecordDeleted = validateRecordDeleted;
const lexicons_1 = require("../../../../lexicons");
const util_1 = require("../../../../util");
const is$typed = util_1.is$typed, validate = lexicons_1.validate;
const id = 'app.bsky.notification.defs';
const hashRecordDeleted = 'recordDeleted';
function isRecordDeleted(v) {
    return is$typed(v, id, hashRecordDeleted);
}
function validateRecordDeleted(v) {
    return validate(v, id, hashRecordDeleted);
}
//# sourceMappingURL=defs.js.map