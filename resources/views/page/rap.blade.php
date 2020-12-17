@extends('master') @section('content')

<div id="heading-breadcrumbs">
  <div class="container">
    <div class="row d-flex align-items-center flex-wrap">
      <div class="col-md-7">
        <h1 class="h2">{{$rap->first()->tenrap}} </h1>
      </div>
      <div class="col-md-5">
        <ul class="breadcrumb d-flex justify-content-end">
          <li class="breadcrumb-item">
            <a href="#">Trang chủ</a>
          </li>
          <li class="breadcrumb-item">
            <a href="he-thong-rap">Rạp</a>
          </li>
        </ul>
      </div>
    </div>
  </div>
</div>

<div id="content">
  <div class="container">
    <section class="bar">
      <div class="row portfolio-project">
        <div class="col-sm-8">
          <div class="project owl-carousel mb-4">
            <div class="item"><img src="sources/img/ok.jpg" alt="" class="img-fluid"></div>
            <div class="item"><img src="sources/img/a.jpg" alt="" class="img-fluid"></div>
            <div class="item"><img src="sources/img/b.jpg" alt="" class="img-fluid"></div>
            <div class="item"><img src="sources/img/c.jpg" alt="" class="img-fluid"></div>
          </div>
        </div>
        <div class="col-sm-4">
          <div class="heading">
            <h4>Thông tin chi tiết</h4>
          </div>
          <div class="project-more">
            <h4>Địa điểm</h4>
            <p>{{$rap->first()->daichi}}</p>
            <h4>Số điện thoại</h4>
            <p>{{$rap->first()->sodt}}</p>
            <h4>Phòng chiếu</h4>
            <p>{{$rap->first()->soluongphong}} phòng</p>
            <h4>Giờ mở cửa</h4>
            <p>{{$rap->first()->giomo}} - {{$rap->first()->giodong}}</p>
          </div>
        </div>
        <div class="col-sm-6">
          <div class="heading">
            <h3>Mô tả</h3>
          </div>
          <p>Đến với {{$rap->first()->tenrap}}, khán giả sẽ được thưởng thức các siêu phẩm của điện ảnh Việt Nam và thế giới tại một hệ thống rạp chiếu phim hiện đại đạt chuẩn Hollywood gồm {{$rap->first()->soluongphong}} phòng chiếu công nghệ 2D &3D cùng hệ thống âm thanh Dolby 7.1 tiêu chuẩn quốc tế theo đúng tiêu chí “Mang Hollywood đến gần bạn”.</p>
          <p>{{$rap->first()->mota}}</p>
        </div>

        <div class="col-sm-6">
          <div class="heading">
            <h3>Bảng giá</h3>
          </div>
          <div class="myprice">
            <img src="sources/img/lotte_price.jpg" alt="" class="img-fluid">
          </div>
        </div>

      </div>
    </section>
  </div>
</div>

@endsection