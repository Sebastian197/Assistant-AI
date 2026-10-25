<?php

namespace Tests;

use Illuminate\Foundation\Testing\TestCase as BaseTestCase;
use Illuminate\Support\Facades\DB;
use RuntimeException;

abstract class TestCase extends BaseTestCase
{
    /**
     * The only database the test suite may migrate and wipe.
     */
    protected const TESTING_DATABASE = 'assistant_ai_testing';

    /**
     * Check the database before any trait runs, because RefreshDatabase
     * wipes the database it points at while setting up its trait.
     *
     * @return array<class-string, class-string>
     */
    protected function setUpTraits(): array
    {
        $this->ensureTestingDatabase();

        return parent::setUpTraits();
    }

    /**
     * Refuse to run against anything but the dedicated PostgreSQL testing database.
     */
    protected function ensureTestingDatabase(): void
    {
        $connection = DB::connection();

        if ($connection->getDriverName() !== 'pgsql' || $connection->getDatabaseName() !== self::TESTING_DATABASE) {
            throw new RuntimeException(sprintf(
                'Tests must run against the PostgreSQL database "%s", but the connection points at the %s database "%s".',
                self::TESTING_DATABASE,
                $connection->getDriverName(),
                $connection->getDatabaseName(),
            ));
        }
    }
}
