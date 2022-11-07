package test.demo.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Arrays;

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

    @Autowired
    private Environment env;


    @GetMapping("/profile")
    public String getProfile () {
        return Arrays.stream(env.getActiveProfiles())
                .findFirst()
                .orElse("")+" version 1";
    }
}
