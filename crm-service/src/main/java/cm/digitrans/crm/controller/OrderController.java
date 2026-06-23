package cm.digitrans.crm.controller;

import cm.digitrans.crm.entity.Order;
import cm.digitrans.crm.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {
    private final OrderService orderService;

    @GetMapping
    public ResponseEntity<List<Order>> getAll() {
        return ResponseEntity.ok(orderService.findAll());
    }

    @GetMapping("/{customerId}")
    public ResponseEntity<List<Order>> getByCustomerId(@PathVariable Long customerId) {
        return ResponseEntity.ok(orderService.findByCustomerId(customerId));
    }

    @PostMapping
    public ResponseEntity<Order> create(@RequestBody Order order) {
        return ResponseEntity.ok(orderService.save(order));
    }
}
