package com.kuang.service;


import com.kuang.pojo.Books;

import java.util.List;

public interface BookService {

    // 增加一本书
    int addBook(Books books);

    // 删除一本书，不是dao层，所以不用加注解@Para("bookId")
    int deleteBookById(int id);

    //更新一本书
    int updateBook(Books books);

    // 查询一本书
    Books queryBookById(int id);

    // 查询全部的书
    List<Books> queryAllBook();

    List<Books> queryBookByName(String bookName);
}
