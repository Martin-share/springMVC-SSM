<%--
  Created by IntelliJ IDEA.
  User: 86136
  Date: 16/10/2023
  Time: 09:29
  To change this template use File | Settings | File Templates.
--%>
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
            <c:forEach var="book" items="${list}">
<%--        <c:forEach var="book" items="${requestScope.get('list')}">--%>
          <tr>
            <td>${book.bookID}</td>
            <td>${book.getBookName()}</td>
            <td>${book.getBookCounts()}</td>
            <td>${book.getDetail()}</td>
            <td>
              <a href="${pageContext.request.contextPath}/book/toUpdateBook?id=${book.bookID}">修改</a>
              
              <a href="${pageContext.request.contextPath}/book/deleteBook?id=${book.getBookID()}">删除</a>
            </td>
          </tr>
        </c:forEach>
        </tbody>
      </table>
    </div>
  </div>


</div>



</body>
</html>