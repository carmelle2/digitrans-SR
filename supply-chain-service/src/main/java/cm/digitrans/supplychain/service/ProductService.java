package cm.digitrans.supplychain.service;

import cm.digitrans.supplychain.entity.Product;
import cm.digitrans.supplychain.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ProductService {
    private final ProductRepository productRepository;

    @Cacheable(value = "products", key = "'all'")
    public List<Product> findAll() {
        return productRepository.findAll();
    }

    public Product save(Product product) {
        return productRepository.save(product);
    }
}
