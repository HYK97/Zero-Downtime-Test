package test.demo.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * packageName :  test.demo.controller
 * fileName : Controller
 * author :  ddh96
 * date : 2022-11-06
 * description :
 * ===========================================================
 * DATE                 AUTHOR                NOTE
 * -----------------------------------------------------------
 * 2022-11-06                ddh96             최초 생성
 */
@RestController
public class TestController {
    private static int serverid= (int) ((Math.random()*3)+1);
    @GetMapping("/serverInfo")
    public String info() {
        return "server1/version/1"+serverid;
    }
}
