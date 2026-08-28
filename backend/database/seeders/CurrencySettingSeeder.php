<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class CurrencySettingSeeder extends Seeder
{
    /**
     * Ensures the currency symbol setting is set to DJF.
     * Runs on every deploy so currency stays correct even after an
     * initial seed has already been applied.
     */
    public function run()
    {
        DB::table('settings')->updateOrInsert(
            ['type' => 'currency_symbol'],
            ['data' => 'DJF', 'updated_at' => now()]
        );
    }
}
