package com.kuang.dao;

import com.kuang.pojo.Books;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface BookMapper {

    // 增加一本书
    int addBook(Books books);

    // 删除一本书,booId和id不一样，所以用个注解转换
    int deleteBookById(@Param("bookID") int id);

    //更新一本书
    int updateBook(Books books);

    // 查询一本书
    Books queryBookById(@Param("bookID") int id);

    // 查询全部的书
    List<Books> queryAllBook();

    // 查询一本书 通过名字
    List<Books> queryBookByName(String bookName);

}
