import { globalIgnores } from 'eslint/config';
import pluginVue from 'eslint-plugin-vue';
import { defineConfigWithVueTs, vueTsConfigs } from '@vue/eslint-config-typescript';
import skipFormatting from '@vue/eslint-config-prettier/skip-formatting';

export default defineConfigWithVueTs(
    globalIgnores([
        'vendor',
        'public',
        'node_modules',
        'bootstrap/ssr',
        'resources/js/actions',
        'resources/js/routes',
        'resources/js/wayfinder',
    ]),
    pluginVue.configs['flat/recommended'],
    vueTsConfigs.recommended,
    skipFormatting,
);
