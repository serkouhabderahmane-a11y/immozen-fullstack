<?php

namespace App\Providers;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\ServiceProvider;
use Opcodes\LogViewer\Facades\LogViewer;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     *
     * @return void
     */
    public function register()
    {
        //
    }

    /**
     * Bootstrap any application services.
     *
     * @return void
     */
    public function boot()
    {
        Schema::defaultStringLength(191);
        if ($this->app->environment('production')) {
            \Illuminate\Support\Facades\URL::forceScheme('https');
        }
        $this->registerSqliteCompatFunctions();
        LogViewer::auth(function () {
            return auth()->check(); // Allow access only if the user is authenticated
        });
    }

    /**
     * The template ships raw MySQL-only SQL (DAYOFWEEK, MONTH, CONCAT, IF).
     * Register equivalents on SQLite so the app also runs on sqlite.
     */
    private function registerSqliteCompatFunctions(): void
    {
        if (\Illuminate\Support\Facades\DB::connection()->getDriverName() !== 'sqlite') {
            return;
        }

        $pdo = \Illuminate\Support\Facades\DB::connection()->getPdo();

        // MySQL DAYOFWEEK: 1 = Sunday ... 7 = Saturday
        $pdo->sqliteCreateFunction('DAYOFWEEK', function ($value) {
            return $value === null ? null : ((int) date('w', strtotime($value)) + 1);
        }, 1);

        // MySQL MONTH: 1 = January ... 12 = December
        $pdo->sqliteCreateFunction('MONTH', function ($value) {
            return $value === null ? null : ((int) date('n', strtotime($value)));
        }, 1);

        $pdo->sqliteCreateFunction('CONCAT', function (...$parts) {
            return implode('', array_map(function ($part) {
                return $part === null ? '' : (string) $part;
            }, $parts));
        });

        $pdo->sqliteCreateFunction('IF', function ($condition, $ifTrue, $ifFalse) {
            return $condition ? $ifTrue : $ifFalse;
        }, 3);
    }
}
