package cm.digitrans.erp.controller;

import cm.digitrans.erp.entity.Employee;
import cm.digitrans.erp.service.EmployeeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/employees")
@RequiredArgsConstructor
public class EmployeeController {
    private final EmployeeService employeeService;

    @GetMapping
    public ResponseEntity<List<Employee>> getAll() {
        return ResponseEntity.ok(employeeService.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Employee> getById(@PathVariable Long id) {
        return ResponseEntity.ok(employeeService.findById(id));
    }

    @PostMapping
    public ResponseEntity<Employee> create(@RequestBody Employee employee) {
        return ResponseEntity.ok(employeeService.save(employee));
    }
}
