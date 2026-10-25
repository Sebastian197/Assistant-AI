<?php

namespace Tests\Feature\Database;

use Illuminate\Support\Facades\DB;
use RuntimeException;
use Tests\TestCase;

class TestDatabaseGuardTest extends TestCase
{
    /**
     * RefreshDatabase wipes the database it points at, so the suite must
     * refuse to refresh anything other than the dedicated testing database.
     */
    public function test_refreshing_any_database_other_than_the_testing_one_is_refused(): void
    {
        config(['database.connections.pgsql.database' => 'assistant_ai']);
        DB::purge('pgsql');

        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage('assistant_ai_testing');

        $this->ensureTestingDatabase();
    }

    public function test_refreshing_the_testing_database_is_allowed(): void
    {
        $this->ensureTestingDatabase();

        $this->assertSame('assistant_ai_testing', DB::connection()->getDatabaseName());
    }
}
