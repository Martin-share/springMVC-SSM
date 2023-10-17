<%--
  Created by IntelliJ IDEA.
  User: 86136
  Date: 17/10/2023
  Time: 10:50
  To change this template use File | Settings | File Templates.
--%>
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
                    <small>查询书籍</small>
                </h1>
            </div>
        </div>
    </div>
    
    <form action="${pageContext.request.contextPath}/book/queryBook" method="post">
        <div class="form-group">
            <label>书籍名称</label>
            <input type="text" name="bookName" class="form-control" required>
        </div>

        <div class="form-group">
            <input type="submit" class="form-control" value="查询">
        </div>
    
    </form>

</div>

</body>
</html>
