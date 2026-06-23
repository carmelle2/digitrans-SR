package cm.digitrans.supplychain.controller;

import cm.digitrans.supplychain.entity.Product;
import cm.digitrans.supplychain.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/products")
@RequiredArgsConstructor
public class ProductController {
    private final ProductService productService;

    @GetMapping
    public ResponseEntity<List<Product>> getAll() {
        return ResponseEntity.ok(productService.findAll());
    }

    @PostMapping
    public ResponseEntity<Product> create(@RequestBody Product product) {
        return ResponseEntity.ok(productService.save(product));
    }
}
