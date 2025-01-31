package com.gestaodespesas.controller;

import com.gestaodespesas.model.Despesas;
import com.gestaodespesas.service.DespesaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/despesas")
public class DespesaController {

    @Autowired
    private DespesaService despesaService;

    @GetMapping
    public List<Despesas> listarTodas() {
        return despesaService.listarTodas();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Despesas> buscarPorId(@PathVariable Long id) {
        Optional<Despesas> despesa = despesaService.buscarPorId(id);
        return despesa.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }

    @PostMapping
    public Despesas criar(@RequestBody Despesas despesa) {
        return despesaService.salvar(despesa);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Despesas> atualizar(@PathVariable Long id, @RequestBody Despesas despesa) {
        return ResponseEntity.ok(despesaService.atualizar(id, despesa));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletar(@PathVariable Long id) {
        despesaService.deletar(id);
        return ResponseEntity.noContent().build();
    }
}