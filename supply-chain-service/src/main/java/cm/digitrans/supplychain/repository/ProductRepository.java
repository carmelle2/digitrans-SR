package cm.digitrans.supplychain.repository;

import cm.digitrans.supplychain.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ProductRepository extends JpaRepository<Product, Long> {
}
