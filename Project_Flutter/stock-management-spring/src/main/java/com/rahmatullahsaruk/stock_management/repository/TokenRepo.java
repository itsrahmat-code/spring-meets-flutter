package com.rahmatullahsaruk.stock_management.repository;
import com.rahmatullahsaruk.stock_management.entity.Token;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

    @Repository
    public interface TokenRepo extends JpaRepository<Token,String> {

        Optional<Token> findByToken(String  token);

        @Query("""
    Select t from Token t inner join User u on t.user.id= u.id
    where t.user.id= :userId and t.logout=false
""")
        List<Token> findAllTokenByUser(int userId);

    }

