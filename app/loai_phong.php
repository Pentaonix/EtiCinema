<?php

namespace App;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;

class loai_phong extends Model
{
    public $timestamps = false;
    protected $table = "loai_phong";

    public function phong_chieu(){
        return $this->hasMany('App\phong_chieu','tenloai','tenloai');
    }
}
