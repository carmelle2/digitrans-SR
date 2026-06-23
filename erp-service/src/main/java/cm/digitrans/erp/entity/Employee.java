package cm.digitrans.erp.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "employees")
@Data
public class Employee {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String nom;
    private String prenom;
    private String role;
    private String departement;
}
