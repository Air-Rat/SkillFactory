import numpy as np
number = np.random.randint(1,101)    # загадали число
print ("Загадано число от 1 до 100")

def halving(number):
    '''Сначала устанавливаем любое random число, а потом отрезок справа или слева в зависимости от 
       того меньше или больше оно нужного. Функция принимает число и возвращает число попыток'''
    count = 1 # счетчик попыток
    predict = np.random.randint(1,101)
    start = 0
    stop = 101
    while number != predict:
        count+=1
        if number > predict: 
            start = predict
        elif number < predict: 
            stop = predict
        predict = (start + stop)//2
    return(count) # выход из цикла, если угадали

def score_game(game_core):
    '''Запускаем игру 1000 раз, чтобы узнать, как быстро игра угадывает число'''
    count_ls = []
    np.random.seed(1)  # фиксируем RANDOM SEED, чтобы ваш эксперимент был воспроизводим!
    random_array = np.random.randint(1,101, size=(1000))
    for number in random_array:
        count_ls.append(game_core(number))
    score = int(np.mean(count_ls))
    print(f"Ваш алгоритм угадывает число в среднем за {score} попыток")
    return(score)

# Проверяем
score_game(halving)