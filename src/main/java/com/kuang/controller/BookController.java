package com.kuang.controller;

import com.kuang.pojo.Books;
import com.kuang.service.BookService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;

@Controller
@RequestMapping("/book")
public class BookController {

    @Autowired
    @Qualifier("BookServiceImpl")
    private BookService bookService;

    @RequestMapping("/allBook")
    public String list(Model model) {
        List<Books> list = bookService.queryAllBook();
        model.addAttribute("list", list);
        return "allBook";
    }

    // allBook.jsp 点击 添加书籍 跳转到 addBook.jsp
    @RequestMapping("/toAddBook")
    public String toAddPaper(){
        return "addBook";
    }

    // addBook.jsp 发送post请求动作 dao层执行 重定位到allBook.jsp
    @RequestMapping("/addBook")
    public String addBook(Books books){
        System.out.println("addBook->"+books);
        bookService.addBook(books);
        return "redirect:/book/allBook";
    }

    @RequestMapping("/toUpdateBook")
    public String toUpdateBook(int id, Model model){
        System.out.println("function: toUpdateBook, Para-id: "+id);
        Books books = bookService.queryBookById(id);
        System.out.println("queryBookById: " + books);
        model.addAttribute("QBook", books);
        return "updateBook";
    }

    //修改书籍
    @RequestMapping("/updateBook")
    public String updateBook( Books books) {
        System.out.println("updateBook=>"+books);
        int i =bookService.updateBook(books);
        if (i > 0) {
            System.out.println("修改books成功"+books);
        }else{
            System.out.println("修改books失败"+books);
        }
        return "redirect:/book/allBook";
    }

    @RequestMapping("/deleteBook")
    public String deleteBook(int id){
        int i = bookService.deleteBookById(id);
        if (i > 0) {
            System.out.println("删除books成功, bookID: "+id);
        }else{
            System.out.println("删除books失败, bookID: "+id);
        }
        return "redirect:/book/allBook";

    }


    @RequestMapping("/queryBook")
    public String queryBook(String queryBookName, Model model){
        List<Books> list = bookService.queryBookByName(queryBookName);
        model.addAttribute("list",list);
        if (list.size() == 0){
            list = bookService.queryAllBook();
            model.addAttribute("error","未查到");
            System.out.println("Not Fund");
        }
        return "allBook";
    }
}