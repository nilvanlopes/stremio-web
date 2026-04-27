// Copyright (C) 2017-2023 Smart code 203358507

const fallbackCopyToClipboard = (text) => {
    if (typeof document === 'undefined' || typeof document.execCommand !== 'function') {
        throw new Error('Clipboard fallback is unavailable');
    }

    const textarea = document.createElement('textarea');
    textarea.value = text;
    textarea.setAttribute('readonly', '');
    textarea.style.position = 'fixed';
    textarea.style.top = '0';
    textarea.style.left = '0';
    textarea.style.opacity = '0';

    document.body.appendChild(textarea);
    textarea.focus();
    textarea.select();
    textarea.setSelectionRange(0, textarea.value.length);

    try {
        if (!document.execCommand('copy')) {
            throw new Error('Clipboard copy command was rejected');
        }
    } finally {
        document.body.removeChild(textarea);
    }
};

const copyToClipboard = async (text) => {
    if (typeof text !== 'string' || text.length === 0) {
        throw new Error('Clipboard text is empty');
    }

    try {
        if (globalThis.navigator?.clipboard?.writeText) {
            await globalThis.navigator.clipboard.writeText(text);
            return;
        }
    } catch (error) {
        try {
            fallbackCopyToClipboard(text);
            return;
        } catch (fallbackError) {
            fallbackError.cause = error;
            throw fallbackError;
        }
    }

    fallbackCopyToClipboard(text);
};

module.exports = copyToClipboard;
