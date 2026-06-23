package cm.digitrans.bi.dto;

import lombok.Data;

@Data
public class LoginRequest {
    private String username;
    private String password;
}
