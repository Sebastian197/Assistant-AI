<?php

use Illuminate\Support\Facades\Route;

Route::view('/', 'app')->name('home');

Route::view('/{path}', 'app')->where('path', '(?!(api|broadcasting|sanctum)(/|$)).+')->name('spa');
