package test.demo.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.Arrays;
import java.util.UUID;

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

    private static String SERVERNUMVER = UUID.randomUUID().toString();
    @GetMapping("/profile")
    public String getProfile () throws UnknownHostException {
        return Arrays.stream(env.getActiveProfiles())
                .findFirst()
                .orElse("")+" version 2 " +SERVERNUMVER;
    }
}
