BGN_EXCHANGE_RATES = {
  usd: 1.7408,
  eur: 1.9557,
  gbp: 2.6415,
  bgn: 1,
}

def convert_to_bgn(price, currency)
  (price * BGN_EXCHANGE_RATES[currency]).round(2)
end

def compare_prices(first_price, first_currency, second_price, second_currency)
    (first_price * BGN_EXCHANGE_RATES[first_currency]) <=>
    (second_price * BGN_EXCHANGE_RATES[second_currency])
end