package com.gestaodespesas.controller;

import com.gestaodespesas.model.Despesas;
import com.gestaodespesas.service.DespesaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/despesas")
public class DespesaController {

    @Autowired
    private DespesaService despesaService;

    // Endpoint para listar todas as despesas
    @GetMapping
    public List<Despesas> listarDespesas() {
        return despesaService.listarDespesas();
    }

    // Endpoint para salvar uma despesa
    @PostMapping
    public Despesas salvarDespesa(@RequestBody Despesas despesa) {
        return despesaService.salvarDespesa(despesa);
    }

    // Endpoint para buscar uma despesa por id
    @GetMapping("/{id}")
    public Optional<Despesas> buscarDespesaPorId(@PathVariable Long id) {
        return despesaService.buscarDespesaPorId(id);
    }
}
