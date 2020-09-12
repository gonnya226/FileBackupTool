
class Test3

    delegate :length, to: :@hoge

    @hoge = "nya-"


end


p Test3.length


