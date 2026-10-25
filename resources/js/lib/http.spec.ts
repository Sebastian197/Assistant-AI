import { describe, expect, it } from 'vitest';
import { http } from '@/lib/http';

describe('http', () => {
    it('sends credentials and the XSRF token', () => {
        expect(http.defaults.withCredentials).toBe(true);
        expect(http.defaults.withXSRFToken).toBe(true);
    });

    it('asks Laravel for JSON responses', () => {
        expect(http.defaults.headers['Accept']).toBe('application/json');
        expect(http.defaults.headers['X-Requested-With']).toBe('XMLHttpRequest');
    });
});
