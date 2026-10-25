import { describe, expect, it } from 'vitest';
import { mount } from '@vue/test-utils';
import { createPinia } from 'pinia';
import { createMemoryHistory } from 'vue-router';
import App from '@/App.vue';
import { createAppRouter } from '@/router';

describe('App', () => {
    it('renders the home page at the root path', async () => {
        const router = createAppRouter(createMemoryHistory());
        await router.push('/');
        await router.isReady();

        const wrapper = mount(App, {
            global: {
                plugins: [createPinia(), router],
            },
        });

        expect(wrapper.get('h1').text()).toBe('Assistant AI');
    });
});
