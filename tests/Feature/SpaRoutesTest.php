<?php

namespace Tests\Feature;

use Tests\TestCase;

class SpaRoutesTest extends TestCase
{
    public function test_home_renders_the_spa_shell(): void
    {
        $response = $this->get('/');

        $response->assertOk();
        $response->assertViewIs('app');
        $response->assertSee('<div id="app"></div>', escape: false);
    }

    public function test_client_side_routes_render_the_spa_shell(): void
    {
        $response = $this->get('/conversations/42');

        $response->assertOk();
        $response->assertViewIs('app');
    }

    public function test_unknown_api_paths_are_not_served_by_the_spa(): void
    {
        $response = $this->getJson('/api/unknown');

        $response->assertNotFound();
    }

    public function test_health_check_still_responds(): void
    {
        $response = $this->get('/up');

        $response->assertOk();
    }
}
