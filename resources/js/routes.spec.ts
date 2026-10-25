import { describe, expect, it } from 'vitest';
import { home } from '@/routes';

describe('Wayfinder routes', () => {
    it('generates a typed helper for the home route', () => {
        expect(home.url()).toBe('/');
    });
});
