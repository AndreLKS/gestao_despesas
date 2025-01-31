package com.gestaodespesas.model;

import javafx.application.Application;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;
import javafx.scene.layout.GridPane;
import javafx.scene.paint.Color;
import javafx.stage.Stage;

public class DespesasApp extends Application {

    public static void main(String[] args) {
        launch(args);
    }

    @Override
    public void start(Stage primaryStage) {
        primaryStage.setTitle("Gestão de Despesas");

        // Criando os componentes da interface
        Label descricaoLabel = new Label("Descrição:");
        descricaoLabel.setStyle("-fx-font-size: 14px; -fx-font-weight: bold;");

        TextField descricaoTextField = new TextField();
        descricaoTextField.setPromptText("Digite a descrição da despesa");
        descricaoTextField.setStyle("-fx-padding: 8px; -fx-font-size: 14px; -fx-background-color: #f0f0f0;");

        Label valorLabel = new Label("Valor:");
        valorLabel.setStyle("-fx-font-size: 14px; -fx-font-weight: bold;");

        TextField valorTextField = new TextField();
        valorTextField.setPromptText("Digite o valor");
        valorTextField.setStyle("-fx-padding: 8px; -fx-font-size: 14px; -fx-background-color: #f0f0f0;");

        Button adicionarButton = new Button("Adicionar Despesa");
        adicionarButton.setStyle("-fx-background-color: #4CAF50; -fx-text-fill: white; -fx-font-size: 14px; -fx-padding: 10px; -fx-border-radius: 5px;");
        adicionarButton.setOnMouseEntered(e -> adicionarButton.setStyle("-fx-background-color: #45a049; -fx-text-fill: white; -fx-font-size: 14px; -fx-padding: 10px; -fx-border-radius: 5px;"));
        adicionarButton.setOnMouseExited(e -> adicionarButton.setStyle("-fx-background-color: #4CAF50; -fx-text-fill: white; -fx-font-size: 14px; -fx-padding: 10px; -fx-border-radius: 5px;"));

        // Layout da interface
        GridPane gridPane = new GridPane();
        gridPane.setVgap(15);
        gridPane.setHgap(15);
        gridPane.setPadding(new Insets(20));
        gridPane.setAlignment(Pos.CENTER);

        gridPane.add(descricaoLabel, 0, 0);
        gridPane.add(descricaoTextField, 1, 0);
        gridPane.add(valorLabel, 0, 1);
        gridPane.add(valorTextField, 1, 1);
        gridPane.add(adicionarButton, 1, 2);

        // Ação do botão de adicionar despesa
        adicionarButton.setOnAction(e -> {
            String descricao = descricaoTextField.getText();
            String valor = valorTextField.getText();
            // Lógica para adicionar a despesa (talvez chamar um serviço ou fazer algo com os dados)
            System.out.println("Despesa adicionada: " + descricao + " - R$" + valor);
            descricaoTextField.clear();
            valorTextField.clear();
        });

        // Criando a cena e mostrando a janela
        Scene scene = new Scene(gridPane, 400, 300, Color.WHITE);
        primaryStage.setScene(scene);
        primaryStage.show();
    }
}
