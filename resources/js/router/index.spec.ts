import { describe, expect, it } from 'vitest';
import { createMemoryHistory } from 'vue-router';
import { createAppRouter } from '@/router';

describe('createAppRouter', () => {
    it('resolves the root path to the home route', () => {
        const router = createAppRouter(createMemoryHistory());

        expect(router.resolve('/').name).toBe('home');
    });

    it('resolves unknown paths to the not-found route', () => {
        const router = createAppRouter(createMemoryHistory());

        expect(router.resolve('/does/not/exist').name).toBe('not-found');
    });
});
