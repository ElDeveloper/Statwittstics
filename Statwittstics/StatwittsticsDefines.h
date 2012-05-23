//
//  StatwittsticsDefines.h
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 14/04/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#ifndef Statwittstics_StatwittsticsDefines_h
#define Statwittstics_StatwittsticsDefines_h

#define STATWITTSTICS_VERSION @"1.0"
#define STATWITTSTICS_BUILD   @"XXXX"

#define kDefaultNumberOfTweets 200

#define DEBUG
//#define VERBOSE_DEBUG

#endif

//DG: Imágen de placeholder para la gráfica
//DG: Fondo de el PBTUserView
//DG: Logotipo de la aplicación
//DG: Selección de colores para toda la aplicación
//
//UX: Revisar si hace falta agregar sonidos
//
//PBPlot Framework:
//	+ Graficar número de twitts por hora (distribución)
//SW: Hacer un annotation que sea un UIPopOverController con una tabla de UITableViewTweetCells
//SW: Double-tap que regrese a la posición original (globalRanges), tal vez se necesite una nueva propiedad para los rangos, el movimiento debe ser animado y suave
//
//Statwittstics Framework:
//SW: Generar PBDataSet de número de twitts por hora 
//SW: Añadir prueba de Kolmogorov-Smirnov para dos distribuciones
//SW: Comparar a dos usuarios en función de sus series de tiempo
//	+ Coeficiente de correlación entre de el número de twitts por día
//	+ Coeficiente de correlación entre la hora a la que dos usuarios twittean
//	+ Comparar distribuciones de twitts por hora
//SW: Añadir ticks-labels:
//	+ Tweets por día
//	+ Tweets por semana
//	+ Tweets por mes
