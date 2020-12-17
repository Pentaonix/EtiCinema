@extends('master') @section('content')
<div id="heading-breadcrumbs">
    <div class="container">
        <div class="row d-flex align-items-center flex-wrap">
            <div class="col-md-7">
                <h1 class="h2">Quy định & Điều khoản</h1>
            </div>
            <div class="col-md-5">
                <ul class="breadcrumb d-flex justify-content-end">
                    <li class="breadcrumb-item">
                        <a href="#">Về trang chủ</a>
                    </li>
                    <li class="breadcrumb-item active">Điều khoản dịch vụ</li>
                </ul>
            </div>
        </div>
    </div>
</div>
<div id="content">
    <div class="container">
        <div class="row bar">
            <div class="col-md-12">
                <section>

                    <div id="accordion" role="tablist">
                        <div class="card card-primary">
                            <div id="headingOne" role="tab" class="card-header">
                                <h5 class="mb-0 mt-0">
                                    <a data-toggle="collapse" href="#collapseOne" aria-expanded="false" aria-controls="collapseOne">1. Rủi ro cá nhân khi truy cập</a>
                                </h5>
                            </div>
                            <div id="collapseOne" role="tabpanel" aria-labelledby="headingOne" data-parent="#accordion" class="collapse ">
                                <div class="card-body">
                                    <p>Khi truy cập vào trang web này bạn chấp thuận và đồng ý với việc có thể gặp một số rủi
                                        ro và đồng ý rằng Eti Cinema cũng như các bên liên kết chịu trách nhiệm xây dựng trang
                                        web này sẽ không chịu trách nhiệm pháp lý cho bất cứ thiệt hại nào đối với với bạn
                                        dù là trực tiếp, đặc biệt, ngẫu nhiên, hậu quả để lại, bị phạt hay bất kỳ mất mát,
                                        phí tổn hoặc chi phí có thể phát sinh trực tiếp hay gián tiếp qua việc sử dụng hoặc
                                        chuyển tải dữ liệu từ trang web này, bao gồm nhưng không giới hạn bởi tất cả những
                                        ảnh hưởng do virus, tác động hoặc không tác động đến hệ thống máy vi tính, đường
                                        dây điện thoại, phá hỏng ổ cứng hay các phần mềm chương trình, các lỗi kỹ thuật khác
                                        gây cản trở hoặc trì hoãn việc truyền tải qua máy vi tính hoặc kết nối mạng.

                                    </p>

                                </div>
                            </div>
                        </div>
                        <div class="card card-primary">
                            <div id="headingTwo" role="tab" class="card-header">
                                <h5 class="mb-0 mt-0">
                                    <a data-toggle="collapse" href="#collapseTwo" aria-expanded="false" aria-controls="collapseTwo" class="collapsed">2. Ngưng cấp quyền sử dụng</a>
                                </h5>
                            </div>
                            <div id="collapseTwo" role="tabpanel" aria-labelledby="headingTwo" data-parent="#accordion" class="collapse">
                                <div class="card-body">Các thành viên tham gia ETI Cinema sẽ bị Ngưng cấp quyền sử dụng dịch vụ (xoá nội dung, lock
                                    nick, xoá nick) mà không được báo trước nếu vi phạm một trong những điều sau:
                                    <ul>
                                        <li> Đăng tải những nội dung mang tính khiêu dâm, đồi truỵ, tục tĩu, phỉ báng, hăm doạ
                                            người khác, vi phạm pháp luật hoặc dẫn tới hành vi phạm pháp.</li>
                                        <li>Spam dưới mọi hình thức tại trang web Eti Cinema.</li>
                                        <li>Vi phạm các quy định khác của ETI Cinema</li>
                                        <p>Eti Cinema sẽ không chịu trách nhiệm hay có nghĩa vụ gì đối với các nội dung đó, và
                                            sẽ hợp tác hết mình với cơ quan luật pháp hay tòa án khi có yêu cầu công bố những
                                            hành vi đăng tải thông tin và dữ liệu trái phép này.</p>
                                    </ul>
                                </div>
                            </div>
                        </div>
                        <div class="card card-primary">
                            <div id="headingThree" role="tab" class="card-header">
                                <h5 class="mb-0 mt-0">
                                    <a data-toggle="collapse" href="#collapseThree" aria-expanded="false" aria-controls="collapseThree" class="collapsed"> 3. Về nội dung</a>
                                </h5>
                            </div>
                            <div id="collapseThree" role="tabpanel" aria-labelledby="headingThree" data-parent="#accordion" class="collapse">
                                <div class="card-body">Các thông tin trong trang web này được cung cấp “như đã đăng tải” và không kèm theo bất kỳ
                                    cam kết nào. Ban quản trị Eti Cinema không bảo đảm hay khẳng định sự đúng đắn, tính chính
                                    xác, độ tin cậy hay bất cứ chuẩn mực nào trong việc sử dụng dữ liệu hay kết qủa của việc
                                    sử dụng dữ liệu trên trang web này. Mặc dù Eti Cinema luôn cố gắng đảm bảo rằng tất cả
                                    nội dung trong trang web này đều được cập nhật, chúng tôi không cam kết rằng những thông
                                    tin được đề cập còn đang hiện hành, chính xác và hoàn chỉnh. Mọi thành viên, khi sử dụng
                                    một trong các chức năng sau của Eti Cinema, cần ý thức rằng những hành động của mình cần
                                    phải hoàn toàn phù hợp với luật dân sự và luật bản quyền hiện hành và chịu trách nhiệm
                                    trước pháp luật đối với nội dung mình đưa lên.

                                </div>
                            </div>
                        </div>
                    </div>
                    <p class="text-muted">Trong trường hợp có thắc mắc hoặc khiếu nại cần giải quyết hãy
                        <a href="contact">liên lạc</a> với chúng tôi, chúng tôi sẽ hỗ trợ bạn sớm nhất có thể.</p>
                </section>
            </div>
            <div class="col-sm-3">
                <!-- PAGES MENU -->


            </div>
        </div>
    </div>
</div>
@endsection