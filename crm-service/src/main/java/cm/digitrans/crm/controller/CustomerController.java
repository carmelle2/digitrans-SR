package cm.digitrans.crm.controller;

import cm.digitrans.crm.entity.Customer;
import cm.digitrans.crm.service.CustomerService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/customers")
@RequiredArgsConstructor
public class CustomerController {
    private final CustomerService customerService;

    @GetMapping
    public ResponseEntity<List<Customer>> getAll() {
        return ResponseEntity.ok(customerService.findAll());
    }

    @PostMapping
    public ResponseEntity<Customer> create(@RequestBody Customer customer) {
        return ResponseEntity.ok(customerService.save(customer));
    }
}
