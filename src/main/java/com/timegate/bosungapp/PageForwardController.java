package com.timegate.bosungapp;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class PageForwardController {

    @GetMapping("/")
    public String root() {
        return "forward:/index.jsp";
    }

    @GetMapping("/error")
    public String error() {
        return "forward:/error.jsp";
    }
}
