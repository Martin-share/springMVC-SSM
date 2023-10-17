# SpringMVC:整合SSM

[狂神说SpringMVC05：整合SSM框架](https://mp.weixin.qq.com/s?__biz=Mzg2NTAzMTExNg==&mid=2247484004&idx=1&sn=cef9d881d0a8d7db7e8ddc6a380a9a76&scene=19#wechat_redirect)

## 6.1、环境要求：

- IDEA
- MySQL 5.7.19(我用的8.0+)
- Tomcat 9
- Maven 3.6

**要求：**

需要熟练掌握MySQL数据库，Spring，JavaWeb及MyBatis知识，简单的前端知识；

## 6.2、创建数据库

```plsql
CREATE DATABASE `ssmbuild`;

USE `ssmbuild`;

DROP TABLE IF EXISTS `books`;

CREATE TABLE `books` (
   `bookID` INT(10) NOT NULL AUTO_INCREMENT COMMENT '书id',
   `bookName` VARCHAR(100) NOT NULL COMMENT '书名',
   `bookCounts` INT(11) NOT NULL COMMENT '数量',
   `detail` VARCHAR(200) NOT NULL COMMENT '描述',
   KEY `bookID` (`bookID`)
 ) ENGINE=INNODB DEFAULT CHARSET=utf8

INSERT  INTO `books`(`bookID`,`bookName`,`bookCounts`,`detail`)VALUES
(1,'Java',1,'从入门到放弃'),
(2,'MySQL',10,'从删库到跑路'),
(3,'Linux',5,'从进门到进牢');
```

## 6.3、导入依赖

新建项目，导入依赖junit、mysql、c3p0、servlet、JSP 、Mybatis、Spring，连接数据库

### 1、pom文件依赖

```xml
<dependencies>
        <!--Junit-->
        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>4.12</version>
        </dependency>
        <!--数据库驱动-->
        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <version>8.0.28</version>
        </dependency>
        <!-- 数据库连接池 -->
        <dependency>
            <groupId>com.mchange</groupId>
            <artifactId>c3p0</artifactId>
            <version>0.9.5.5</version>
        </dependency>
        
        <!--Servlet - JSP -->
        <dependency>
            <groupId>javax.servlet</groupId>
            <artifactId>servlet-api</artifactId>
            <version>2.5</version>
        </dependency>
        <dependency>
            <groupId>javax.servlet.jsp</groupId>
            <artifactId>jsp-api</artifactId>
            <version>2.2</version>
        </dependency>
        <dependency>
            <groupId>javax.servlet</groupId>
            <artifactId>jstl</artifactId>
            <version>1.2</version>
        </dependency>
        
        <!--Mybatis-->
        <dependency>
            <groupId>org.mybatis</groupId>
            <artifactId>mybatis</artifactId>
            <version>3.5.6</version>
        </dependency>
        <dependency>
            <groupId>org.mybatis</groupId>
            <artifactId>mybatis-spring</artifactId>
            <version>2.0.2</version>
        </dependency>
        
        <!--Spring-->
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-webmvc</artifactId>
            <version>5.2.0.RELEASE</version>
        </dependency>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-jdbc</artifactId>
            <version>5.2.0.RELEASE</version>
        </dependency>
        
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <version>1.18.10</version>
        </dependency>
    </dependencies>
```

### 2、数据库

![img](https://cdn.nlark.com/yuque/0/2023/png/29248125/1675301498855-4dd74132-4b4e-4592-b8bc-1ab2a7cfbf30.png)

### 3、maven静态资源导出问题

```xml
<build>
  <resources>
    <resource>
      <directory>src/main/java</directory>
      <includes>
        <include>**/*.properties</include>
        <include>**/*.xml</include>
      </includes>
      <filtering>false</filtering>
    </resource>
    <resource>
      <directory>src/main/resources</directory>
      <includes>
        <include>**/*.properties</include>
        <include>**/*.xml</include>
      </includes>
      <filtering>false</filtering>
    </resource>
  </resources>
</build>
```

## 6.4、基本架构和配置文件

建立包结构

- com.kuang.pojo
- com.kuang.dao
- com.kuang.service
- com.kuang.controller

配置文件

- mybatis-config.xml
- applicationContext.xml
- database.properties

**mybatis-config.xml**

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration
        PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>

    <typeAliases>
        <package name="com.kuang.pojo"/>
    </typeAliases>
    
</configuration>
```

**applicationContext.xml**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.springframework.org/schema/beans
  http://www.springframework.org/schema/beans/spring-beans.xsd">

</beans>
```

**database.properties**

```properties
jdbc.driver=com.mysql.jdbc.Driver
jdbc.url=jdbc:mysql://localhost:3306/ssmbuild?useSSL=true&useUnicode=true&characterEncoding=utf8
jdbc.username=root
jdbc.password=root
```

## 6.5、Mybatis层

### 实体类pojo层

字段和数据库内的一样

```java
package com.kuang.pojo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Books {

    private int bookID;
    private String bookName;
    private int bookCounts;
    private String detail;

}
```

![img](https://cdn.nlark.com/yuque/0/2023/png/29248125/1675301886319-e655a7a8-0581-4d0f-8c0a-6d69a707c627.png)

### 接口dao层

**BookMapper**

```java
package com.kuang.dao;

import com.kuang.pojo.Books;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface BookMapper {

    // 增加一本书
    int addBook(Books books);

    // 删除一本书,booId和id不一样，所以用个注解转换
    // 注解的名字和pojo一定要一样！
    int deleteBookById(@Param("bookID") int id);

    //更新一本书
    int updateBook(Books books);

    // 查询一本书
    Books queryBookById(@Param("bookID") int id);

    // 查询全部的书
    List<Books> queryAllBook();

}
```

**BookMapper.xml**

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
        PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">

<mapper namespace="com.kuang.dao.BookMapper">
    
    <!--增加一个Book-->
    <insert id="addBook" parameterType="Books">
        insert into ssmbuild.books(bookName,bookCoun ts,detail)
        values (#{bookName}, #{bookCounts}, #{detail})
    </insert>
    
    <!--根据id删除一个Book-->
    <delete id="deleteBookById" parameterType="int">
        delete from ssmbuild.books where bookID=#{bookID}
    </delete>
    
    <!--更新Book-->
    <update id="updateBook" parameterType="Books">
        update ssmbuild.books
        set bookName = #{bookName},bookCounts = #{bookCounts},detail = #{detail}
        where bookID = #{bookID}
    </update>
    
    <!--根据id查询,返回一个Book-->
    <select id="queryBookById" resultType="Books">
        select * from ssmbuild.books
        where bookID = #{bookID}
    </select>
    
    <!--查询全部Book-->
    <select id="queryAllBook" resultType="Books">
        SELECT * from ssmbuild.books
    </select>

</mapper>
```

**mybatis-config.xml**

**接口和mapper写完了，就要绑定到xml中**

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration
        PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
    
    <!--  配置数据源，交给 Spring 去做  -->
    <typeAliases>
        <package name="com.kuang.pojo"/>
    </typeAliases>
    
    <mappers>
        <mapper class="com.kuang.dao.BookMapper"/>
    </mappers>

</configuration>
```

### 业务service层

**BookService**

```java
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

}
```

**BookServiceImpl**

```java
package com.kuang.service;


import com.kuang.dao.BookMapper;
import com.kuang.pojo.Books;

import java.util.List;

public class BookServiceImpl implements BookService{

    // service调 dao层：组合Dao
    private BookMapper bookMapper;

    public void setBookMapper(BookMapper bookMapper) {
        this.bookMapper = bookMapper;
    }

    @Override
    public int addBook(Books books) {
        return bookMapper.addBook(books);
    }

    @Override
    public int deleteBookById(int id) {
        return bookMapper.deleteBookById(id);
    }

    @Override
    public int updateBook(Books books) {
        return bookMapper.updateBook(books);
    }

    @Override
    public Books queryBookById(int id) {
        return bookMapper.queryBookById(id);
    }

    @Override
    public List<Books> queryAllBook() {
        return bookMapper.queryAllBook();
    }
}
```

## 6.6、Spring层

**spring-dao.xml**

将这个上下午配置到之前`applicationContext.xml`的上下文

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/context
        https://www.springframework.org/schema/context/spring-context.xsd">
    
    <!-- 配置整合mybatis -->
    <!-- 1.关联数据库文件 -->
    <context:property-placeholder location="classpath:database.properties"/>
    
    <!-- 2.数据库连接池 -->
    <!--数据库连接池
        dbcp 半自动化操作 不能自动连接
        c3p0 自动化操作（自动的加载配置文件 并且设置到对象里面）
    -->
    <bean id="dataSource" class="com.mchange.v2.c3p0.ComboPooledDataSource">
        <!-- 配置连接池属性 -->
        <property name="driverClass" value="${jdbc.driver}"/>
        <property name="jdbcUrl" value="${jdbc.url}"/>
        <property name="user" value="${jdbc.username}"/>
        <property name="password" value="${jdbc.password}"/>
        
        <!-- c3p0连接池的私有属性 -->
        <property name="maxPoolSize" value="30"/>
        <property name="minPoolSize" value="10"/>
        <!-- 关闭连接后不自动commit -->
        <property name="autoCommitOnClose" value="false"/>
        <!-- 获取连接超时时间 -->
        <property name="checkoutTimeout" value="10000"/>
        <!-- 当获取连接失败重试次数 -->
        <property name="acquireRetryAttempts" value="2"/>
    </bean>
    
    <!-- 3.配置SqlSessionFactory对象 -->
    <bean id="sqlSessionFactory" class="org.mybatis.spring.SqlSessionFactoryBean">
        <!-- 注入数据库连接池 -->
        <property name="dataSource" ref="dataSource"/>
        <!-- 配置MyBaties全局配置文件:mybatis-config.xml -->
        <property name="configLocation" value="classpath:mybatis-config.xml"/>
    </bean>
    
    <!-- 4.配置扫描Dao接口包，动态实现Dao接口注入到spring容器中 -->
    <!--解释 ：https://www.cnblogs.com/jpfss/p/7799806.html-->
    <bean class="org.mybatis.spring.mapper.MapperScannerConfigurer">
        <!-- 注入sqlSessionFactory -->
        <property name="sqlSessionFactoryBeanName" value="sqlSessionFactory"/>
        <!-- 给出需要扫描Dao接口包 -->
        <property name="basePackage" value="com.kuang.dao"/>
    </bean>

</beans>
```

**spring-service.xml**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
  http://www.springframework.org/schema/beans/spring-beans.xsd
  http://www.springframework.org/schema/context
  http://www.springframework.org/schema/context/spring-context.xsd">
    
    <!-- 1. 扫描service相关的bean -->
    <context:component-scan base-package="com.kuang.service" />
    
    <!--2. BookServiceImpl注入到IOC容器中-->
    <bean id="BookServiceImpl" class="com.kuang.service.BookServiceImpl">
        <property name="bookMapper" ref="bookMapper"/>
    </bean>
    
    <!-- 3. 配置事务管理器 -->
    <bean id="transactionManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
        <!-- 注入数据库连接池 -->
        <property name="dataSource" ref="dataSource" />
    </bean>

</beans>
```

若配置的上下文没有自动整合，可以手动导入

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
  http://www.springframework.org/schema/beans/spring-beans.xsd">

    <import resource="classpath:spring-dao.xml"/>
    <import resource="classpath:spring-service.xml"/>
    <import resource="classpath:spring-mvc.xml"/>
</beans>
```

## 6.7、SpringMVC层

增加web框架支持！

**web.xml**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee http://xmlns.jcp.org/xml/ns/javaee/web-app_4_0.xsd"
  version="4.0">

  <!--DispatcherServlet-->
  <servlet>
    <servlet-name>springmvc</servlet-name>
    <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
    <init-param>
      <param-name>contextConfigLocation</param-name>
      <!--一定要注意:我们这里加载的是总的配置文件，之前被这里坑了！-->
      <param-value>classpath:applicationContext.xml</param-value>
    </init-param>
    <load-on-startup>1</load-on-startup>
  </servlet>
  <servlet-mapping>
    <servlet-name>springmvc</servlet-name>
    <url-pattern>/</url-pattern>
  </servlet-mapping>

  <!--乱码过滤 encodingFilter-->
  <filter>
    <filter-name>encodingFilter</filter-name>
    <filter-class>
      org.springframework.web.filter.CharacterEncodingFilter
    </filter-class>
    <init-param>
      <param-name>encoding</param-name>
      <param-value>utf-8</param-value>
    </init-param>
  </filter>
  <filter-mapping>
    <filter-name>encodingFilter</filter-name>
    <url-pattern>/*</url-pattern>
  </filter-mapping>

  <!--Session过期时间-->
  <session-config>
    <session-timeout>15</session-timeout>
  </session-config>

</web-app>
```

**spring-mvc.xml**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:context="http://www.springframework.org/schema/context"
  xmlns:mvc="http://www.springframework.org/schema/mvc"
  xsi:schemaLocation="http://www.springframework.org/schema/beans
  http://www.springframework.org/schema/beans/spring-beans.xsd
  http://www.springframework.org/schema/context
  http://www.springframework.org/schema/context/spring-context.xsd
  http://www.springframework.org/schema/mvc
  https://www.springframework.org/schema/mvc/spring-mvc.xsd">

  <!-- 配置SpringMVC -->
  <!-- 1.开启SpringMVC注解驱动 -->
  <mvc:annotation-driven />
  <!-- 2.静态资源默认servlet配置-->
  <mvc:default-servlet-handler/>

  <!-- 3.配置jsp 显示ViewResolver视图解析器 -->
  <bean class="org.springframework.web.servlet.view.InternalResourceViewResolver">
    <property name="viewClass" value="org.springframework.web.servlet.view.JstlView" />
    <property name="prefix" value="/WEB-INF/jsp/" />
    <property name="suffix" value=".jsp" />
  </bean>

  <!-- 4.扫描web相关的bean -->
  <context:component-scan base-package="com.kuang.controller" />

</beans>
```

**BookController**

```java
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
}
```

**allBook.jsp**

```html
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
  <html>
    <head>
      <title>书籍展示</title>
    </head>
    <body>
      <h1>书籍展示</h1>
    </body>
  </html>
```

**index.jsp**

```html
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
  <title>首页</title>
</head>
<body>

<h3>
  <a href="${pageContext.request.contextPath}/book/allBook">进入书籍页面</a>
</h3>

</body>
</html>
```

## 排错思路

### 问题：启动不了，工件 ssmbuild:war exploded: 部署工件时出错。请参阅服务器日志了解详细信息。

web-inf下先建立 lib库，然后在其中加maven静态资源

![img](https://cdn.nlark.com/yuque/0/2023/png/29248125/1675305257489-2505a8c3-6e40-4ce1-a129-f45c2d565d22.png)

![img](https://cdn.nlark.com/yuque/0/2023/png/29248125/1697420193549-545f397b-8a91-49a1-9929-48c513fb8a06.png)

### 问题：bean不存在（500）

**步骤：**

1、查看这个bean注入是否成功！
2、Junit单元测试，看我们的代码是否能够查询出来结果！

```java
import com.kuang.pojo.Books;
import com.kuang.service.BookService;
import org.junit.Test;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;

public class MyTest {
    @Test
    public void test(){
        ApplicationContext context = new ClassPathXmlApplicationContext("applicationContext.xml");
        BookService bookServiceImpl = (BookService) context.getBean("BookServiceImpl");

        for (Books books:bookServiceImpl.queryAllBook()){
            System.out.println(books);
        }

    }
}
```


3、问题，一定不在我们的底层，是spring出了问题！
4、SpringMVC，整合的时候没调用到我们的service.层的bean

- applicationContext.xml没有注入bean
- web.xml中，我们也绑定过配置文件！发现问题，我们配置的是Spring-mvc.Xml这里面确实没有service bean,所以报空指针
- 所以，在web.xml中`<param-value>classpath:applicationContext.xml</param-value>`而不是`<param-value>classpath:spring-mvc.xml</param-value>`

## 6.8、查询书籍

**index.jsp**

```html
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
  <html>
    <head>
      <title>首页</title>
      <style>
        a{
          text-decoration: none;
          color: blue;
          font-size: 18px;
        }
        h3{
          width: 180px;
          height: 38px;
          margin: 100px auto;
          text-align: center;
          line-height: 38px;
          background: deepskyblue;
          border-radius: 5px;
        }
      </style>

    </head>
    <body>

      <h3>
        <a href="${pageContext.request.contextPath}/book/allBook">进入书籍页面</a>
      </h3>

    </body>
  </html>
```

查找BootStrap CDN，搜索

```html
<!-- 新 Bootstrap 核心 CSS 文件 -->

<link href="https://cdn.staticfile.org/twitter-bootstrap/3.3.7/css/bootstrap.min.css" rel="stylesheet">

<!-- jQuery文件。务必在bootstrap.min.js 之前引入 -->

<script src="https://cdn.staticfile.org/jquery/2.1.1/jquery.min.js"></script>

<!-- 最新的 Bootstrap 核心 JavaScript 文件 -->

<script src="https://cdn.staticfile.org/twitter-bootstrap/3.3.7/js/bootstrap.min.js"></script>
```

**allbook.jsp**

- 先导入<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>，放第一行

```html
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
  <%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <html>
      <head>
        <title>书籍展示</title>

        <!-- 新 Bootstrap 核心 CSS 文件 -->

        <link href="https://cdn.staticfile.org/twitter-bootstrap/3.3.7/css/bootstrap.min.css" rel="stylesheet">

        <!-- jQuery文件。务必在bootstrap.min.js 之前引入 -->

        <script src="https://cdn.staticfile.org/jquery/2.1.1/jquery.min.js"></script>

        <!-- 最新的 Bootstrap 核心 JavaScript 文件 -->

        <script src="https://cdn.staticfile.org/twitter-bootstrap/3.3.7/js/bootstrap.min.js"></script>
      </head>
      <body>

        <div class="container">

          <div class="row clearfix">
            <div class="col-md-12 column">
              <div class="page-header">
                <h1>
                  <small>书籍列表 —— 显示所有书籍</small>
                </h1>
              </div>
            </div>
          </div>

          <div class="row clearfix">
            <div class="col-md-12 column">
              <table class="table table-hover table-striped">
                <thead>
                  <tr>
                    <th>书籍编号</th>
                    <th>书籍名字</th>
                    <th>书籍数量</th>
                    <th>书籍详情</th>
                    <th>操作</th>
                  </tr>
                </thead>

                <%-- 书籍从数据库中查询出来，从这个List中遍历出来：foreach --%>
                  <tbody>
                    <%--                <c:forEach var="book" items="${requestScope.get('list')}">--%>
                      <c:forEach var="book" items="${requestScope.get('list')}">
                        <tr>
                          <td>${book.getBookID()}</td>
                          <td>${book.getBookName()}</td>
                          <td>${book.getBookCounts()}</td>
                          <td>${book.getDetail()}</td>
                        </tr>
                      </c:forEach>
                    </tbody>
                    </table>
                    </div>
                    </div>


                    </div>



                    </body>
                    </html>
```

![img](https://cdn.nlark.com/yuque/0/2023/png/29248125/1675305760922-1937ad3f-8337-4357-84af-9686f4910358.png)

## 6.9、添加书籍

**allBook.jsp**

```html
<div class="row">
  <div class="col-md-4 column">
    <a class="btn btn-primary" href="${pageContext.request.contextPath}/book/toAddBook">新增书籍</a>
  </div>
</div>
```

**BookController.java**

```java
// 跳转到增加书籍页面
@RequestMapping("/toAddBook")
    public String toAddPaper(){
    return "addBook";
}

// 添加书籍
@RequestMapping("/addBook")
public String addBook(Books books){
    System.out.println("addBook=>"+books);
    bookService.addBook(books);
    return "redirect:/book/allBook";
}
```

**addBook.jsp**

```html
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
  <%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <html>
      <head>
        <title>书籍展示</title>

        <%--  BootStrap美化界面  --%>
          <link href="https://cdn.staticfile.org/twitter-bootstrap/3.3.7/css/bootstrap.min.css" rel="stylesheet">
      </head>
      <body>

        <div class="container">

          <div class="row clearfix">
            <div class="col-md-12 column">
              <div class="page-header">
                <h1>
                  <small>新增书籍</small>
                </h1>
              </div>
            </div>
          </div>

          <!-- 下方表格的name必须和实体类pojo的 属性名 一模一样 否则无法注入 -->
          <form action="${pageContext.request.contextPath}/book/addBook" method="post">
            <div class="form-group">
              <label>书籍名称</label>
              <input type="text" name="bookName" class="form-control" required>
            </div>
            <div class="form-group">
              <label>书籍数量</label>
              <input type="text" name="bookCounts" class="form-control" required>
            </div>
            <div class="form-group">
              <label>书籍描述</label>
              <input type="text" name="detail" class="form-control" required>
            </div>
            <div class="form-group">
              <input type="submit" class="form-control" value="添加">
            </div>

          </form>

        </div>

      </body>
    </html>
```

**结果**
![img](https://cdn.nlark.com/yuque/0/2023/png/29248125/1675306141540-ea3d9251-5048-4243-8073-c2b64224e2bd.png)

![img](https://cdn.nlark.com/yuque/0/2023/png/29248125/1675306151793-aae16b63-8b93-4e26-98bf-9983f6620d50.png)

## 6.10、修改书籍

**allBook.jsp**

```html
<tbody>
  <c:forEach var="book" items="${requestScope.get('list')}">
    <tr>
      <td>${book.getBookID()}</td>
      <td>${book.getBookName()}</td>
      <td>${book.getBookCounts()}</td>
      <td>${book.getDetail()}</td>
      <td>
        <a href="${pageContext.request.contextPath}/book/toUpdateBook?id=${book.getBookID()}">修改</a>
      </td>
    </tr>
  </c:forEach>
</tbody>
```

**BookController.java**

```java
// 点击修改书籍按钮 跳转到 updateBook.jsp
@RequestMapping("/toUpdateBook")
public String toUpdateBook(int id, Model model){
    Books books = bookService.queryBookById(id);
    model.addAttribute("QBook",books);
    return "updateBook";
}
```

**updateBook.jsp**

```html
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>修改书籍信息</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- 引入 Bootstrap -->
    <link href="https://cdn.bootcss.com/bootstrap/3.3.7/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container">
    
    <div class="row clearfix">
        <div class="col-md-12 column">
            <div class="page-header">
                <h1>
                    <small>修改书籍</small>
                </h1>
            </div>
        </div>
    </div>
    
    <form action="${pageContext.request.contextPath}/book/updateBook" method="post">
        <div class="form-group">
            <label>书籍名称</label>
            <input type="text" name="bookName" class="form-control" value="${QBook.bookName}" required>
        </div>
        <div class="form-group">
            <label>书籍数量</label>
            <input type="text" name="bookCounts" class="form-control" value="${QBook.bookCounts}" required>
        </div>
        <div class="form-group">
            <label>书籍描述</label>
            <input type="text" name="detail" class="form-control" value="${QBook.detail}" required>
        </div>
        <div class="form-group">
            <input type="submit" class="form-control" value="修改">
        </div>
        <%--        <input type="submit" value="提交"/>--%>
    </form>

</div>
```

BookController

```java
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
```

**结果**

![img](https://cdn.nlark.com/yuque/0/2023/png/29248125/1675240681927-18895598-dc2c-406e-b86d-4f6adc8beb9b.png)



**排错**   可以进入修改书籍页面，但是提交修改按钮，无法提交到数据库

加上事务试试？

导入jar包

```xml
<dependency>
    <groupId>org.aspectj</groupId>
    <artifactId>aspectjweaver</artifactId>
    <version>1.9.4</version>
</dependency>
```

然后在项目结构-工件-lib库下导入maven资源

**加上事务**

**spring-service.xml**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:context="http://www.springframework.org/schema/context"
  xmlns:aop="http://www.springframework.org/schema/aop"
  xmlns:tx="http://www.springframework.org/schema/tx"
  xsi:schemaLocation="http://www.springframework.org/schema/beans
  http://www.springframework.org/schema/beans/spring-beans.xsd
  http://www.springframework.org/schema/context
  http://www.springframework.org/schema/context/spring-context.xsd
  http://www.springframework.org/schema/aop
  http://www.springframework.org/schema/aop/spring-aop.xsd
  http://www.springframework.org/schema/tx
  http://www.springframework.org/schema/tx/spring-tx.xsd">

  <!-- 扫描service相关的bean -->
  <context:component-scan base-package="com.kuang.service" />

  <!--BookServiceImpl注入到IOC容器中-->
  <bean id="BookServiceImpl" class="com.kuang.service.BookServiceImpl">
    <property name="bookMapper" ref="bookMapper"/>
  </bean>

  <!-- 配置事务管理器 -->
  <bean id="transactionManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
    <!-- 注入数据库连接池 -->
    <property name="dataSource" ref="dataSource" />
  </bean>

  <!--  结合AOP实现事务的织入  -->
  <!-- 配置事务通知 -->
  <tx:advice id="txAdvice" transaction-manager="transactionManager">
    <tx:attributes>
      <tx:method name="*" propagation="REQUIRED"/>
    </tx:attributes>
  </tx:advice>

  <!--  配置事务切入  -->
  <aop:config>
    <aop:pointcut id="txPointCut" expression="execution(* com.kuang.dao.*.*(..))"/>
    <aop:advisor advice-ref="txAdvice" pointcut-ref="txPointCut"/>
  </aop:config>

</beans>
```



 出现的问题：我们提交了修改的SQ请求，但是修改失败，初次考虑，是事务问题，配置完华事务，依旧失败！

看一下SQL语句，能否执行成功：SQL执行失败，修政未完成-

sql语句执行失败，原因update时需要提交bookID,但是前端提交的表单默认bookID是0，所以错误



**updateBook.jsp**

```html
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
  <%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <html>
      <head>
        <title>修改书籍信息</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <!-- 引入 Bootstrap -->
        <link href="https://cdn.bootcss.com/bootstrap/3.3.7/css/bootstrap.min.css" rel="stylesheet">
      </head>
      <body>
        <div class="container">

          <div class="row clearfix">
            <div class="col-md-12 column">
              <div class="page-header">
                <h1>
                  <small>修改书籍</small>
                </h1>
              </div>
            </div>
          </div>

          <%--  出现的问题：我们提交了修改的SQ请求，但是修改失败，初次考虑，是事务问题，配置完华事务，依旧失败！--%>
            <%-- 看一下SQL语句，能否执行成功：SQL执行失败，修政未完成-%>  &ndash;%&gt;--%>
              <form action="${pageContext.request.contextPath}/book/updateBook" method="post">
                <input type="hidden" name="bookID" value="${QBook.bookID}">
                <div class="form-group">
                  <label>书籍名称</label>
                  <input type="text" name="bookName" class="form-control" value="${QBook.bookName}" required>
                </div>
                <div class="form-group">
                  <label>书籍数量</label>
                  <input type="text" name="bookCounts" class="form-control" value="${QBook.bookCounts}" required>
                </div>
                <div class="form-group">
                  <label>书籍描述</label>
                  <input type="text" name="detail" class="form-control" value="${QBook.detail}" required>
                </div>
                <div class="form-group">
                  <input type="submit" class="form-control" value="修改">
                </div>
                <%--        <input type="submit" value="提交"/>--%>
              </form>

            </div>
```

手动添加日志

mybatis-config.xml

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration
        PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
    
    <settings>
        <setting name="logImpl" value="STDOUT_LOGGING"/>
    </settings>
    
    <!--  配置数据源，交给 Spring 去做  -->
    <typeAliases>
        <package name="com.kuang.pojo"/>
    </typeAliases>
    
    
    <mappers>
        <mapper class="com.kuang.dao.BookMapper"/>
    </mappers>


</configuration>
```

## 6.11、删除书籍

```java
//删除书籍
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
```

**allBook.jsp**

```html
<td>
  <a href="${pageContext.request.contextPath}/book/toUpdateBook?id=${book.getBookID()}">修改</a>
  <a href="${pageContext.request.contextPath}/book/deleteBook?id=${book.getBookID()}">删除</a>
</td>
```

## 6.12、查询书籍

**BookMapper**

```java
List<Books> queryBookByName(String bookName);
```

**BookMapper.xml**

```xml
<select id="queryBookByName" resultType="Books">
    SELECT * from ssmbuild.books where bookName like CONCAT('%',#{bookName},'%')
</select>
```

**BookService**

```java
List<Books> queryBookByName(String bookName);
```

**BookServiceImpl**

```java
@Override
public List<Books> queryBookByName(String bookName){
    return bookMapper.queryBookByName(bookName);
}
```

**allBook.jsp**

```java
 <div class="row">
  <div class="col-md-4 column">
    <a class="btn btn-primary" href="${pageContext.request.contextPath}/book/toAddBook">新增书籍</a>
  </div>
  <div class="col-md-4 column">
    <%-- 查询书籍--%>
      <form action="${pageContext.request.contextPath}/book/queryBook" method="post" style="float: right">
        <input type="text" name="queryBookName" class="form-control" placeholder="请输入要查询书籍的名称">
        <input type="submit" value="查询" class="btn btn-primary">
      </form>
  </div>
</div>
```

**BookController**

```java
//查询书籍
@RequestMapping("/queryBook")
public String queryBook(String queryBookName, Model model){
    List<Books> list = bookService.queryBookByName(queryBookName);
    model.addAttribute("list",list);
    return "allBook";
}
```

**结果**

![img](https://cdn.nlark.com/yuque/0/2023/png/29248125/1675307013304-31c18821-98ac-4a2a-abf5-78c6359c1b2a.png)
报500错误，dao.BookMapper.xml查不到

加上maven资源过滤

```xml
<build>
  <resources>
    <resource>
      <directory>src/main/java</directory>
      <includes>
        <include>**/*.properties</include>
        <include>**/*.xml</include>
      </includes>
      <filtering>false</filtering>
    </resource>
    <resource>
      <directory>src/main/resources</directory>
      <includes>
        <include>**/*.properties</include>
        <include>**/*.xml</include>
      </includes>
      <filtering>false</filtering>
    </resource>
  </resources>
</build>
```

## 6.13、优化未找到书籍的的显示界面

**allBook.jsp**

```html
<div class="row">
  <div class="col-md-4 column">
    <a class="btn btn-primary" href="${pageContext.request.contextPath}/book/toAddBook">新增书籍</a>
    <a class="btn btn-primary" href="${pageContext.request.contextPath}/book/allBook">显示全部书籍</a>
  </div>
  <div class="col-md-8 column">
    <%-- 查询书籍--%>
      <form class="form-inline" action="${pageContext.request.contextPath}/book/queryBook" method="post" style="float: right">
        <span style="color:red; font-weight: bold">${error}</span>
        <input type="text" name="queryBookName" class="form-control" placeholder="请输入要查询书籍的名称">
        <input type="submit" value="查询" class="btn btn-primary">
      </form>
  </div>
</div>
```

**BookController**

```java
//查询书籍
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
```

结果
![img](https://cdn.nlark.com/yuque/0/2023/png/29248125/1675240682928-5ad00b5f-e1c4-49c8-84f5-d16ba96b8177.png)

# 