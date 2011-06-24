package com.cursodeardruino.light;

import java.util.Map;

/**
 * Simples classe abstrata para definir os m�todos de Http e uma 
 * factory para criar a implementa��o correta
 * 
 * @author ricardo
 *
 */
public abstract class Http {
	//utiliza UrlConnection
	public static final int NORMAL 	= 1;
	//Utiliza o Jakarta HttpClient
	public static final int JAKARTA = 2;
	public static Http getInstance(int tipo){
		switch (tipo) {
			case NORMAL:
				//UrlConnection
				return new HttpNormalImpl();
			case JAKARTA:
				//Jakarta Commons HttpClient
				return new HttpClientImpl();
		default:
			return new HttpNormalImpl();
		}
	}
	//retorna o texto do arquivo
	public abstract String downloadArquivo(String url);
	//retorna os bytes da imagem
	public abstract byte[] downloadImagem(String url);
	//faz post enviando os par�metros
	public abstract String doPost(String url, Map map);
}