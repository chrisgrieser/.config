export function findMatchingTemplate(url, templates, schemaOrgData) {
    return templates.find(template => template.triggers && template.triggers.some(pattern => matchPattern(pattern, url, schemaOrgData)));
}
export function matchPattern(pattern, url, schemaOrgData) {
    if (pattern.startsWith('schema:')) {
        return matchSchemaPattern(pattern, schemaOrgData);
    }
    else if (pattern.startsWith('/') && pattern.endsWith('/')) {
        try {
            const regexPattern = new RegExp(pattern.slice(1, -1));
            return regexPattern.test(url);
        }
        catch (error) {
            console.error(`Invalid regex pattern: ${pattern}`, error);
            return false;
        }
    }
    else {
        return url.startsWith(pattern);
    }
}
function matchSchemaPattern(pattern, schemaOrgData) {
    const [, schemaKey, expectedValue] = pattern.match(/schema:(.+?)(?:=(.+))?$/) || [];
    if (!schemaKey)
        return false;
    const actualValue = getSchemaValue(schemaOrgData, schemaKey);
    if (expectedValue) {
        if (Array.isArray(actualValue)) {
            return actualValue.includes(expectedValue);
        }
        return actualValue === expectedValue;
    }
    else {
        return !!actualValue;
    }
}
function getSchemaValue(schemaData, key) {
    if (Array.isArray(schemaData)) {
        for (const item of schemaData) {
            const value = getSchemaValue(item, key);
            if (value !== undefined)
                return value;
        }
        return undefined;
    }
    const keys = key.split('.');
    let result = schemaData;
    for (const k of keys) {
        if (result && typeof result === 'object' && k in result) {
            result = result[k];
        }
        else {
            return undefined;
        }
    }
    return result;
}
//# sourceMappingURL=triggers.js.map