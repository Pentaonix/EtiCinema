<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class hoa_don_khuyen_mai extends Model
{
    protected $table = "hoa_don_khuyen_mai";

    public function hoa_don(){
        return $this->belongsTon('App\hoa_don','mahoadon','');
    }

    public function rap_khuyen_mai(){
        return $this->hasMany('App\rap_khuyen_mai','id','mahoadon');
    }
}
