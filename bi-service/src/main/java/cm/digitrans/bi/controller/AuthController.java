package cm.digitrans.bi.controller;

import cm.digitrans.bi.dto.LoginRequest;
import cm.digitrans.bi.dto.LoginResponse;
import cm.digitrans.bi.security.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {
    private final JwtUtil jwtUtil;

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@RequestBody LoginRequest request) {
        String token = jwtUtil.generateToken(request.getUsername());
        return ResponseEntity.ok(new LoginResponse(token));
    }
}
