<?php

namespace Tests\Feature\Database;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

class PostgresSetupTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Tests must never run against the development database, because
     * RefreshDatabase wipes whatever database it is pointed at.
     */
    public function test_tests_run_against_the_dedicated_postgres_database(): void
    {
        $this->assertSame('pgsql', DB::connection()->getDriverName());
        $this->assertSame('assistant_ai_testing', DB::connection()->getDatabaseName());
    }

    /**
     * Vector columns and similarity queries need the pgvector extension.
     */
    public function test_pgvector_extension_is_enabled(): void
    {
        $this->assertNotNull(DB::selectOne("select 1 from pg_extension where extname = 'vector'"));
    }
}
