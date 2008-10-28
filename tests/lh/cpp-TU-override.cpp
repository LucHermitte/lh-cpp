// Vim: let b:tags_dirname = '.'
//
namespace nZ { 
    class B {};
} // nZ namespace 


namespace foo { 
    class A0
    {
	virtual ~A0() = 0;
	virtual void a0();
    };

    class A1
    {
	virtual ~A1();
	virtual void f1(std::string const& s) = 0;
	virtual void f2() { f1("foo"); }
	void f2(int);

[]
    };

    class A2 : virtual A0 
    {
	virtual ~A2() {}
	virtual void g();
	virtual void a0();

['A0']
    }

    class A3 : virtual A0
    {
	void a0();

['A0']
    }

    class C1 : A1, A2
    {
	virtual ~C1();
	void f2(); 

['A0', 'A1', 'A2']
    };

    class D : C1, virtual A0
    {
	virtual void g();

['A0', 'A1', 'A2', 'C1']
    };
    class B : A0{};
} // foo namespace 

namespace bar { 
    using namespace nZ;
    struct V {};
    struct Z {};
    struct C1 : virtual V {};
    struct C2 : virtual V, Z {};
    struct C3 : C2{};
    struct D : C1, C3, B {};
// echo lh#cpp#AnalysisLib_Class#Ancestors('bar::D')
} // bar namespace 



