import com.kuang.pojo.Books;
import com.kuang.service.BookService;
import org.junit.Test;
import org.springframework.context.support.ClassPathXmlApplicationContext;

public class MyTest {
    @Test
    public void testBookController(){
        ClassPathXmlApplicationContext context = new ClassPathXmlApplicationContext("applicationContext.xml");
        BookService bookServiceImpl = (BookService) context.getBean("BookServiceImpl");

        for (Books books : bookServiceImpl.queryAllBook()) {
            System.out.println(books);
        }
    }
}
