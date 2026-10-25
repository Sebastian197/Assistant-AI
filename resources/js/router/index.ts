import { createRouter, createWebHistory, type Router, type RouterHistory } from 'vue-router';
import HomePage from '@/pages/HomePage.vue';
import NotFoundPage from '@/pages/NotFoundPage.vue';

export function createAppRouter(history: RouterHistory = createWebHistory()): Router {
    return createRouter({
        history,
        routes: [
            { path: '/', name: 'home', component: HomePage },
            { path: '/:pathMatch(.*)*', name: 'not-found', component: NotFoundPage },
        ],
    });
}
