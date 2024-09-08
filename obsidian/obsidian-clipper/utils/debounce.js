export function debounce(func, wait) {
    let timeout = null;
    return function (...args) {
        const context = this;
        if (timeout)
            clearTimeout(timeout);
        timeout = setTimeout(() => func.apply(context, args), wait);
    };
}
//# sourceMappingURL=debounce.js.map