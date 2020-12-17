<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class khach_hang extends Model
{
    public $timestamps = false;
    protected $table = "khach_hang";

    public function users(){
        return $this->belongsTo('App\User','id','idkh');
    }

    public function hoa_don(){
        return $this->hasMany('App\hoa_don','matk_kh','idkh');
    }
}
